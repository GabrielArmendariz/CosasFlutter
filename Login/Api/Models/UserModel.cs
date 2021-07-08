using BusinessLogic;

namespace Api.Models
{
    public class UserModel
    {
        public string Username { set; get; }
        public string Password { set; get; }

        public UserModel(string u, string p){
            Username = u;
            Password = p;
        }
        public User ToEntity(){
            return new User(Username, Password);
        }
    }
}