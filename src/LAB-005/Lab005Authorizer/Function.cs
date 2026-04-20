using System.Text.Json.Serialization;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace Lab005Authorizer;

public class Function
{
    private const string AllowedToken = "Bearer lab005-allow";

    public AuthorizerResponse FunctionHandler(AuthorizerRequest request, ILambdaContext context)
    {
        var authHeader = ReadAuthorizationHeader(request.Headers);
        var isAuthorized = string.Equals(authHeader, AllowedToken, StringComparison.Ordinal);

        context.Logger.LogInformation(
            "Authorizer decision: route={0}, authorized={1}, tokenPrefix={2}",
            request.RouteKey ?? "(unknown)",
            isAuthorized,
            MaskToken(authHeader));

        return new AuthorizerResponse
        {
            IsAuthorized = isAuthorized,
            Context = isAuthorized
                ? new Dictionary<string, string>(StringComparer.Ordinal)
                {
                    ["tenantId"] = "tenant-lab005",
                    ["plan"] = "pro"
                }
                : new Dictionary<string, string>(StringComparer.Ordinal)
                {
                    ["reason"] = "invalid_token"
                }
        };
    }

    private static string? ReadAuthorizationHeader(IDictionary<string, string>? headers)
    {
        if (headers is null)
        {
            return null;
        }

        return headers.TryGetValue("authorization", out var lower)
            ? lower
            : headers.TryGetValue("Authorization", out var exact)
                ? exact
                : null;
    }

    private static string MaskToken(string? token)
    {
        if (string.IsNullOrEmpty(token))
        {
            return "(missing)";
        }

        return token.Length <= 12 ? "***" : $"{token[..12]}***";
    }
}

public class AuthorizerRequest
{
    [JsonPropertyName("routeKey")]
    public string? RouteKey { get; set; }

    [JsonPropertyName("headers")]
    public Dictionary<string, string>? Headers { get; set; }
}

/// <summary>
/// HTTP API payload 2.0 + simple responses wymagają camelCase w JSON (dokumentacja AWS).
/// </summary>
public class AuthorizerResponse
{
    [JsonPropertyName("isAuthorized")]
    public bool IsAuthorized { get; set; }

    [JsonPropertyName("context")]
    public Dictionary<string, string>? Context { get; set; }
}
