using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace Lab005Business;

public class Function
{
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var routeKey = request.RouteKey ?? string.Empty;
        context.Logger.LogInformation("Business invoke routeKey={0}", routeKey);

        if (routeKey.StartsWith("GET /public", StringComparison.Ordinal))
        {
            return Json(200, new
            {
                route = "public",
                message = "Endpoint publiczny (bez custom authorizera)."
            });
        }

        if (routeKey.StartsWith("GET /profile", StringComparison.Ordinal))
        {
            return Json(200, new
            {
                route = "profile",
                message = "Dostep przyznany przez Lambda authorizer.",
                note = "TODO(lab-005): odczytaj context authorizera i zwroc tenant/plan."
            });
        }

        return Json(404, new { message = "Nieobslugiwany routeKey.", routeKey });
    }

    private static APIGatewayHttpApiV2ProxyResponse Json(int status, object body) => new()
    {
        StatusCode = status,
        Headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Content-Type"] = "application/json"
        },
        Body = JsonSerializer.Serialize(body)
    };
}
