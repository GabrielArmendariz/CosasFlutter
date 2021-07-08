using TechTalk.SpecFlow;
using NUnit.Framework;
using LoginBDD.Classes;
using Moq;

namespace LoginBDD.Steps
{
    [Binding]
    public class LoginSteps
    {
        private Login login;
        private Mock<IDatabase> mock;
        private bool result;

        [Given(@"I access the application")]
        public void GivenAccess(){
            mock = new Mock<IDatabase>(MockBehavior.Strict);
            login = new Login(mock.Object);
        }

        [When(@"I press Login with valid user info")]
        public void WhenPressValidLogin(){
            mock.Setup(m => m.Exists(It.IsAny<string>(),It.IsAny<string>()))
                .Returns(true);
            result = login.LoginMethod("Gabriel", "password");
        }

        [When(@"I press Login with invalid user info")]
        public void WhenPressInvalidLogin(){
            mock.Setup(m => m.Exists(It.IsAny<string>(),It.IsAny<string>()))
                .Returns(false);
            result = login.LoginMethod("Gabriel", "password");
        }

        [Then(@"I should be able to access the app")]
        public void ThenLogin(){
            Assert.That(result == true);
        }

        [Then(@"I should not be able to access the app")]
        public void ThenLoginFail(){
            Assert.That(result == false);
        }
    }
}