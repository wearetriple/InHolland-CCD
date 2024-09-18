using Microsoft.AspNetCore.Mvc;

namespace DemoObservableApplication.Controllers;
[ApiController]
[Route("[controller]")]
public class UnobservableController : ControllerBase
{
    private readonly ILogger<UnobservableController> _logger;

    public UnobservableController(ILogger<UnobservableController> logger)
    {
        _logger = logger;
    }

    [HttpGet]
    public IActionResult Get()
    {
        if (!Condition())
        {
            if (Condition())
            {
                return BadRequest();
            }
            else if (Condition())
            {
                if (Condition())
                {
                    return NoContent();
                }
                else if (Condition())
                {
                    return Ok();
                }
                else if (Condition())
                {
                    return Accepted();
                }
                else
                {
                    return Conflict();
                }
            }
            else
            {
                return NotFound();
            }
        }
        else
        {
            return Ok();
        }
    }

    private bool Condition() => Random.Shared.NextDouble() > 0.5;
}
