using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ImageLabFunction;

public class Function
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var routeKey = request.RouteKey ?? string.Empty;
        context.Logger.LogInformation("Invoke routeKey={0}", routeKey);

        if (routeKey.StartsWith("GET /health", StringComparison.Ordinal))
        {
            var labId = Environment.GetEnvironmentVariable("LAB_ID") ?? "LAB-009";
            var imageTag = Environment.GetEnvironmentVariable("IMAGE_TAG") ?? "unknown";

            return Json(200, new
            {
                status = "ok",
                labId,
                routeKey,
                deployment = new
                {
                    packageType = "Image",
                    imageTag,
                    note = "IMAGE_TAG ustaw w Dockerfile (build-arg) albo w definicji obrazu — TODO(lab-009)."
                }
            });
        }

        return Json(404, new { message = "Nieobsługiwany routeKey.", routeKey });
    }

    private static APIGatewayHttpApiV2ProxyResponse Json(int status, object body) => new()
    {
        StatusCode = status,
        Headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Content-Type"] = "application/json"
        },
        Body = JsonSerializer.Serialize(body, JsonOptions)
    };
}
