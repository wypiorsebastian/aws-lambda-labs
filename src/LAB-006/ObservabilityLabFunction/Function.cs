using System.Diagnostics;
using System.Text.Json;
using Amazon.Lambda.APIGatewayEvents;
using Amazon.Lambda.Core;
using AWS.Lambda.Powertools.Logging;
using AWS.Lambda.Powertools.Metrics;
using AWS.Lambda.Powertools.Tracing;

[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace ObservabilityLabFunction;

public class Function
{
    private static bool _isColdStart = true;
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    [Logging(LogEvent = false, CorrelationIdPath = "/requestContext/requestId")]
    [Tracing(CaptureMode = TracingCaptureMode.ResponseAndError)]
    [Metrics(Namespace = "AwsLambdaLabs/LAB-006", Service = "public-api")]
    public APIGatewayHttpApiV2ProxyResponse FunctionHandler(
        APIGatewayHttpApiV2ProxyRequest request,
        ILambdaContext context)
    {
        var routeKey = request.RouteKey ?? string.Empty;
        var requestId = request.RequestContext?.RequestId ?? context.AwsRequestId;
        var stopwatch = Stopwatch.StartNew();

        // Structured log for the request envelope (without sensitive headers/body).
        Logger.LogInformation("Request start routeKey={RouteKey} requestId={RequestId}", routeKey, requestId);
        Logger.AppendKey("routeKey", routeKey);
        Logger.AppendKey("requestId", requestId);
        Logger.AppendKey("coldStart", _isColdStart);

        try
        {
            APIGatewayHttpApiV2ProxyResponse response = routeKey switch
            {
                var r when r.StartsWith("GET /health", StringComparison.Ordinal) => Json(200, new
                {
                    status = "ok",
                    service = "lab006-public-api",
                    coldStart = _isColdStart
                }),
                var r when r.StartsWith("GET /orders/", StringComparison.Ordinal) => Json(200, new
                {
                    orderId = request.PathParameters is not null && request.PathParameters.TryGetValue("orderId", out var orderId) ? orderId : "unknown",
                    status = "processing",
                    note = "TODO(lab-006): podlacz dane z realnego backendu."
                }),
                var r when r.StartsWith("GET /fail", StringComparison.Ordinal) => throw new InvalidOperationException("Intentional failure for observability path."),
                _ => Json(404, new { message = "Nieobslugiwany route.", routeKey })
            };

            Metrics.AddMetric("RequestsTotal", 1, MetricUnit.Count);
            Metrics.AddMetric("SuccessfulRequests", response.StatusCode is >= 200 and < 500 ? 1 : 0, MetricUnit.Count);

            stopwatch.Stop();
            Logger.LogInformation("Request finished statusCode={StatusCode} durationMs={DurationMs}", response.StatusCode, stopwatch.ElapsedMilliseconds);
            return response;
        }
        catch (Exception ex)
        {
            Metrics.AddMetric("RequestsTotal", 1, MetricUnit.Count);
            Metrics.AddMetric("ServerErrors", 1, MetricUnit.Count);

            Logger.LogError(ex, "Request failed routeKey={RouteKey} requestId={RequestId}", routeKey, requestId);
            return Json(500, new
            {
                message = "Internal Server Error",
                requestId
            });
        }
        finally
        {
            _isColdStart = false;
        }
    }

    private static APIGatewayHttpApiV2ProxyResponse Json(int statusCode, object body) => new()
    {
        StatusCode = statusCode,
        Headers = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            ["Content-Type"] = "application/json"
        },
        Body = JsonSerializer.Serialize(body, JsonOptions)
    };
}
