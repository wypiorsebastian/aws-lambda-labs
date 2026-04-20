using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace JwtLabFunction;

public class Function
{
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var routeKey = request.RouteKey ?? string.Empty;
        context.Logger.LogInformation("Invoke routeKey={0}", routeKey);

        if (routeKey.StartsWith("GET /public", StringComparison.Ordinal))
        {
            return Json(200, new
            {
                route = "public",
                message = "Brak JWT — endpoint publiczny."
            });
        }

        if (routeKey.StartsWith("GET /claims", StringComparison.Ordinal))
        {
            var claims = request.RequestContext?.Authorizer?.Jwt?.Claims;
            if (claims is null || claims.Count == 0)
            {
                return Json(500, new { message = "Brak claims w kontekście — sprawdź JWT authorizer i nagłówek Authorization." });
            }

            var sub = ReadClaim(claims, "sub");
            var tokenUse = ReadClaim(claims, "token_use");
            var iss = ReadClaim(claims, "iss");

            var cognitoUsername = ReadClaim(claims, "cognito:username");
            if (string.IsNullOrEmpty(cognitoUsername))
            {
                cognitoUsername = ReadClaim(claims, "username");
            }

            return Json(200, new
            {
                route = "claims",
                preview = new
                {
                    sub,
                    username = cognitoUsername,
                    token_use = tokenUse,
                    iss
                },
                note = "Pełny zestaw claims i token nie są zwracane ani logowane."
            });
        }

        return Json(404, new { message = "Nieobsługiwany routeKey.", routeKey });
    }

    private static string? ReadClaim(IDictionary<string, string> claims, string key) =>
        claims.TryGetValue(key, out var value) ? value : null;

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
