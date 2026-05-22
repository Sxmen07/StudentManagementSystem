using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;

//Change the database name here if your database different than mine
public class DBHelper
{
    private static string connStr = ConfigurationManager.ConnectionStrings["StudentManagementSystem"].ConnectionString;

    //Get SQL connection
    public static SqlConnection GetConnection()
    {
        return new SqlConnection(connStr);
    }

    //Execute Query and return DataTable
    public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
    {
        DataTable dt = new DataTable();
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            conn.Open();
            SqlDataAdapter da = new SqlDataAdapter(cmd);
            da.Fill(dt);
        }
        return dt;
    }

    //Execute query and return number of affected rows
    public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
    {
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            conn.Open();
            return cmd.ExecuteNonQuery();
        }
    }

    //Execute query and return single value
    public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
    {
        using (SqlConnection conn = GetConnection())
        using (SqlCommand cmd = new SqlCommand(query, conn))
        {
            if (parameters != null) cmd.Parameters.AddRange(parameters);
            conn.Open();
            return cmd.ExecuteScalar();
        }
    }
}