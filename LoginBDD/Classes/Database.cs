namespace LoginBDD.Classes
{
    public interface IDatabase{
        bool Exists(string username, string password);
    }
    public class Database : IDatabase
    {
        public bool Exists(string username, string password){
            return username == "Gabriel" && password == "123";
        }
    }
}