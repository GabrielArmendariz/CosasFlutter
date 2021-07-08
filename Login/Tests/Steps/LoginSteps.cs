using Api.Controllers;
using Api.Models;
using BusinessLogic;
using Microsoft.AspNetCore.Mvc;
using Moq;
using NUnit.Framework;
using TechTalk.SpecFlow;

namespace Tests.Steps
{
    [Binding]
    public class LoginSteps
    {
        private LoginController login;
        private Mock<ILoginLogic> mock;
        private IActionResult result;
        private string username;
        private string password;

        [BeforeScenario]
        public void SetupTestCase(){
            mock = new Mock<ILoginLogic>(MockBehavior.Strict);
            login = new LoginController(mock.Object);
            username = "";
            password = "";
        }

        [AfterScenario]
        public void ClearTestCase(){
            result = null;
            mock = null;
            login = null;
        }

        [Given(@"A valid username")]
        public void GivenValidUsername(){
            username = "gabriel";
            mock.Setup(m => m.ValidateUsername(It.IsAny<string>())).Returns(true);
        }

        [Given(@"An invalid username")]
        public void GivenInvalidUsername(){
            username = "jose";
            mock.Setup(m => m.ValidateUsername(It.IsAny<string>())).Returns(false);
        }

        [Given(@"A valid password")]
        public void GivenValidPassword(){
            password = "password";
            mock.Setup(m => m.ValidateCredentials(It.IsAny<string>(), It.IsAny<string>())).Returns(true);
        }

        [Given(@"An invalid password")]
        public void GivenInvalidPassword(){
            password = "pasword";
            mock.Setup(m => m.ValidateCredentials(It.IsAny<string>(), It.IsAny<string>())).Returns(false);
        }

        [When(@"I press Login")]
        public void WhenPressValidLogin(){            
            result = login.Post(new UserModel(username,password));
        }

        [Then(@"I should be able to access the app")]
        public void ThenLogin(){
            //mock.VerifyAll();
            Assert.IsInstanceOf(typeof(OkResult),result);
        }

        [Then(@"I should not be able to access the app")]
        public void ThenFailLogin(){
            //mock.VerifyAll();
            Assert.IsInstanceOf(typeof(BadRequestResult),result);
        }
    }
}