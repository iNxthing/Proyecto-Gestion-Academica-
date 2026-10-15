/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package sistemadegestionacademica;

/**
 *
 * @author nothing
 */
public class infoConexion {
        
    String url = "jdbc:mysql://localhost/gestion_academica";
    String username = "root";
    String password = "72564025";

    public infoConexion() {
    }

    public String getUrl() {
        return url;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }
}
