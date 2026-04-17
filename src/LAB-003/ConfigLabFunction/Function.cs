using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using Amazon.SecretsManager;
using Amazon.SecretsManager.Model;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ConfigLabFunction;

public class Function
{
    private static readonly AmazonSecretsManagerClient SecretsClient = new();

    public async Task<APIGatewayHttpApiV2ProxyResponse> FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var appEnv = Environment.GetEnvironmentVariable("APP_ENV") ?? "(unset)";
        var publicToggle = Environment.GetEnvironmentVariable("PUBLIC_FEATURE_TOGGLE") ?? "(unset)";
        var secretArn = Environment.GetEnvironmentVariable("SECRET_ARN");

        context.Logger.LogInformation(
            "GET /config; APP_ENV={0}; PUBLIC_FEATURE_TOGGLE={1}; hasSecretArn={2}",
            appEnv,
            publicToggle,
            !string.IsNullOrEmpty(secretArn));

        if (string.IsNullOrWhiteSpace(secretArn))
        {
            return JsonError(500, new { message = "SECRET_ARN is not configured" });
        }

        string? demoApiKey;
        try
        {
            var response = await SecretsClient.GetSecretValueAsync(
                new GetSecretValueRequest { SecretId = secretArn });

            if (string.IsNullOrEmpty(response.SecretString))
            {
                return JsonError(500, new { message = "Secret has no SecretString payload" });
            }

            demoApiKey = TryGetDemoApiKey(response.SecretString);
        }
        catch (Exception ex)
        {
            context.Logger.LogError($"Secrets Manager call failed: {ex.GetType().Name}: {ex.Message}");
            return JsonError(502, new { message = "Could not read secret (see CloudWatch for error type only)" });
        }

        var preview = SafeKeyPreview(demoApiKey);

        var body = new
        {
            appEnv,
            publicFeatureToggle = publicToggle,
            demoApiKeyLast4 = preview,
            note = "Full secret value is never returned or logged."
        };

        return JsonOk(body);
    }

    private static string? TryGetDemoApiKey(string secretJson)
    {
        using var doc = JsonDocument.Parse(secretJson);
        return doc.RootElement.TryGetProperty("demoApiKey", out var el)
            ? el.GetString()
            : null;
    }

    /// <summary>
    /// Zwraca ostatnie 4 znaki albo maskę — nigdy pełnej wartości.
    /// </summary>
    private static string SafeKeyPreview(string? key)
    {
        if (string.IsNullOrEmpty(key))
            return "(missing in JSON)";

        return key.Length <= 4
            ? "****"
            : key[^4..];
    }

    private static APIGatewayHttpApiV2ProxyResponse JsonOk(object payload)
    {
        return new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = 200,
            Headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["Content-Type"] = "application/json; charset=utf-8"
            },
            Body = JsonSerializer.Serialize(payload)
        };
    }

    private static APIGatewayHttpApiV2ProxyResponse JsonError(int statusCode, object payload)
    {
        return new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = statusCode,
            Headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                ["Content-Type"] = "application/json; charset=utf-8"
            },
            Body = JsonSerializer.Serialize(payload)
        };
    }
}
