using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace FeatureFlagsFunction;

public class Function
{
    private static readonly List<FlagItem> SampleFlags =
    [
        new("beta-dashboard", true, "Beta dashboard rollout"),
        new("new-nav", false, "New navigation shell"),
        new("invoice-export", true, "Async invoice export")
    ];

    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var routeKey = request?.RequestContext?.RouteKey ?? "$default";
        var method = request?.RequestContext?.Http?.Method ?? "UNKNOWN";
        var path = request?.RawPath ?? "/";

        context.Logger.LogInformation($"RouteKey={routeKey}; Method={method}; Path={path}");

        return routeKey switch
        {
            "GET /flags" => HandleGetFlags(request!, context),
            "POST /flags" => HandlePostFlags(request!),
            "ANY /flags/{flagKey}" => HandleFlagByKey(request!, method),
            "$default" => HandleDefault(request!),
            _ => HandleDefault(request!)
        };
    }

    private static APIGatewayHttpApiV2ProxyResponse HandleGetFlags(APIGatewayHttpApiV2ProxyRequest request, ILambdaContext context)
    {
        var enabledOnly = TryGetQueryBool(request?.QueryStringParameters, "enabled");
        context.Logger.LogInformation($"----SEBA LOG: {enabledOnly}");
        context.Logger.LogError($"----SEBA LOG: {enabledOnly}");
        IEnumerable<FlagItem> items = SampleFlags;
        if (enabledOnly is true)
            items = items.Where(f => f.Enabled);
        else if (enabledOnly is false)
            items = items.Where(f => !f.Enabled);

        return JsonResponse(200, new { items = items.ToList() });
    }

    private static bool? TryGetQueryBool(
        IDictionary<string, string>? query,
        string key)
    {
        if (query is null || !query.TryGetValue(key, out var raw) || string.IsNullOrEmpty(raw))
            return null;
        var first = raw.Split(',')[0].Trim();
        return bool.TryParse(first, out var b) ? b : null;
    }

    private static APIGatewayHttpApiV2ProxyResponse HandlePostFlags(APIGatewayHttpApiV2ProxyRequest request)
    {
        if (string.IsNullOrWhiteSpace(request?.Body))
            return JsonResponse(400, new { message = "Body is required" });

        CreateFlagRequest? dto;
        try
        {
            dto = JsonSerializer.Deserialize<CreateFlagRequest>(request.Body);
        }
        catch (JsonException)
        {
            return JsonResponse(400, new { message = "Invalid JSON" });
        }

        if (string.IsNullOrWhiteSpace(dto?.Key))
            return JsonResponse(400, new { message = "Field 'key' is required" });

        return JsonResponse(201, new
        {
            message = "Parsed (no persistence in this lab)",
            received = new { dto.Key, dto.Enabled, dto.Description }
        });
    }

    private static APIGatewayHttpApiV2ProxyResponse HandleFlagByKey(APIGatewayHttpApiV2ProxyRequest request, string method)
    {
        string? key = null;
        if (request?.PathParameters is { } pp && pp.TryGetValue("flagKey", out var fk))
            key = fk;
        if (string.IsNullOrWhiteSpace(key))
            return JsonResponse(400, new { message = "Missing path parameter flagKey" });

        var flag = SampleFlags.FirstOrDefault(f =>
            string.Equals(f.Key, key, StringComparison.OrdinalIgnoreCase));

        return method.ToUpperInvariant() switch
        {
            "GET" when flag is null => JsonResponse(404, new { message = "Flag not found", key }),
            "GET" => JsonResponse(200, flag),
            "PUT" => JsonResponse(200, new { message = "Would update (no persistence)", key }),
            "DELETE" => JsonResponse(200, new { message = "Would delete (no persistence)", key }),
            _ => JsonResponse(405, new { message = "Method not allowed", method })
        };
    }

    private static APIGatewayHttpApiV2ProxyResponse HandleDefault(APIGatewayHttpApiV2ProxyRequest? request)
    {
        var payload = new
        {
            message = "Route not found",
            routeKey = request?.RequestContext?.RouteKey,
            rawPath = request?.RawPath
        };

        return JsonResponse(404, payload);
    }

    private static APIGatewayHttpApiV2ProxyResponse JsonResponse(int statusCode, object payload)
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

    private sealed record FlagItem(string Key, bool Enabled, string Description);

    private sealed class CreateFlagRequest
    {
        public string? Key { get; set; }
        public bool Enabled { get; set; }
        public string? Description { get; set; }
    }
}
