using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Api.Models;
using BusinessLogic;
using Microsoft.AspNetCore.Mvc;

namespace Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LoginController : ControllerBase
    {

        private ILoginLogic loginLogic;

        public LoginController(ILoginLogic logic){
            loginLogic = logic;
        }
        
        // POST api/values
        [HttpPost]
        public IActionResult Post([FromBody] UserModel model)
        {
            if(loginLogic.ValidateUsername(model.Username) && loginLogic.ValidateCredentials(model.Username, model.Password)){
                return Ok();
            }
            else{
                return BadRequest();
            }
        }

    }
}