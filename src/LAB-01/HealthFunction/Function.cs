using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace HealthFunction;

public class Function
{
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var method = request?.RequestContext?.Http?.Method ?? "UNKNOWN";
        var path = request?.RawPath ?? "/";

        context.Logger.LogInformation($"Request received: {method} {path}");

        var payload = new
        {
            status = "ok",
            service = "health-reporter",
            timestamp = DateTimeOffset.UtcNow.ToString("O")
        };

        return new APIGatewayHttpApiV2ProxyResponse
        {
            StatusCode = 200,
            Headers = new Dictionary<string, string>
            {
                ["Content-Type"] = "application/json"
            },
            Body = System.Text.Json.JsonSerializer.Serialize(payload)
        };
    }
}