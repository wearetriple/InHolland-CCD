using Microsoft.AspNetCore.Mvc;

namespace DemoObservableApplication.Controllers;
[ApiController]
[Route("[controller]")]
public class ObservableController : ControllerBase
{
    private readonly ILogger<ObservableController> _logger;

    public ObservableController(ILogger<ObservableController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        HttpContext.Response.Headers.Append("X-Trace", HttpContext.TraceIdentifier);

        if (!Condition(0.1))
        {
            _logger.LogInformation("No cache was found");

            if (Condition(0.2))
            {
                _logger.LogInformation("Invalid request");

                return BadRequest();
            }
            else if (Condition(0.7))
            {
                _logger.LogInformation("Item found in database");

                if (Condition(0.25))
                {
                    _logger.LogInformation("Found item contained no data");

                    return NoContent();
                }
                else if (Condition(0.25))
                {
                    _logger.LogInformation("Found item contained data -- adding to cache");

                    return Ok();
                }
                else if (Condition(0.25))
                {
                    _logger.LogInformation("Triggered creation of item with {Id}", Guid.NewGuid());

                    return Accepted();
                }
                else
                {
                    _logger.LogInformation("Item found with duplicate data {@Data}", new { Item1 = "Item", Item2 = "Item" });

                    return Conflict();
                }
            }
            else
            {
                _logger.LogInformation("Item not found in database");

                return NotFound();
            }
        }
        else
        {
            _logger.LogInformation("Cache was found");

            return Ok();
        }
    }

    private bool Condition(double limit) => Random.Shared.NextDouble() < limit;
}
