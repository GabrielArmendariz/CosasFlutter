using System;

namespace LoginBDD.Classes
{
    public class Login
    {
        private IDatabase database;
        public Login(IDatabase db){
            database = db;
        }

        public bool LoginMethod(string u, string p){
            return database.Exists(u,p);
        }
    }
}