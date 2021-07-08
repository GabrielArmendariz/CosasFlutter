using System;
using System.Collections.Generic;

namespace BusinessLogic
{
    public interface ILoginLogic
    {
        bool ValidateUsername(string username);
        bool ValidateCredentials(string username, string password);
    }

    public class LoginLogic : ILoginLogic
    {
        private List<User> validUsers;

        public LoginLogic(){
            validUsers = new List<User>();
            validUsers.Add(new User("gabriel","password"));
        }

        public bool ValidateUsername(string username)
        {
            return validUsers.Exists(x => x.Username == username);
        }

        public bool ValidateCredentials(string username, string password){
            return validUsers.Exists(x => x.Username == username && x.Password == password);
        }
    }

    public class User{
        public string Username { set; get; }
        public string Password { set; get; }

        public User(string u, string p){
            Username = u;
            Password = p;
        }
    }
}

