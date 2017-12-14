/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package proyectofinal;
import java.sql.*;
import javax.swing.JTable;
import javax.swing.JComboBox;
import java.util.ArrayList;

/**
 *
 * @author anacr
 */
public class Conexion {
    String connectionUrl = "jdbc:sqlserver://172.16.202.84:443;database=CaribbeanSoul;user=Cris;password=Bases1";  

      // Declare the JDBC objects.  
      Connection con = null;  
      Statement stmt = null;  
      ResultSet rs = null;  
      
      private String hileraResultado;
    
    public Conexion() {
        hileraResultado = "";
    }
    
    public String getHileraResultado() {
        return hileraResultado;
    }
    
    public boolean consulta(String sql) {
        boolean exito = true;
        try {
            //Se abre la conexion utilizando el driver de oracle
            //DriverManager.registerDriver (new oracle.jdbc.OracleDriver());
            // ó Class.forName ("oracle.jdbc.OracleDriver");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");  
            con = DriverManager.getConnection(connectionUrl);  
            stmt = con.createStatement();  
              
           
            
            //Se ejecuta la instruccion SQL
            boolean consulta = stmt.execute(sql);
            
            if(consulta) {
                //Si el resultado es 'true' significa que hubo una consulta con resultado
                //resultado = comando.getResultSet();
               rs = stmt.executeQuery(sql);
                
                //Se saca el MetaData para conocer la informacion del ResultSet
                //El MetaData contiene toda la informacion sobre la tabla generada por la consulta
                ResultSetMetaData metaData = rs.getMetaData();
                
                //Por ejemplo, sacamos la cantidad de columnas del resultado
                int cantidad= metaData.getColumnCount();
                
                hileraResultado = "";
                while(rs.next()) {
                    //Se itera uno a uno por las filas (el comando next() cambia de fila)
                    String n = "";
                    for (int i=1; i<=cantidad; i++) {
                        //Se saca la informacion de cada columna
                        n += rs.getString(i) + " - ";
                    }
                    hileraResultado += n + "\n";
                    //System.out.println(n);
                }
                rs.close();
            } else {
                //Como no se ejecuto una consulta, no se produjo ningun ResultSet
                hileraResultado = "";

                System.out.println("comando SQL ejecutado correctamente");
            }
            //Hay que cerrar la conexion
            rs.close();
            stmt.close();
            con.close();
        } catch (Exception e) {
            //Es muy importante el try-catch para atrapar los posibles errores
            //que pueden ocurrir en las distintas consultas y comandos SQL
            System.out.println(e.getMessage());
            exito = false;
        }
        //Se retorna si la ejecucion tuvo exito o no
        return exito;
    }
    
    public void llenarCombobox(String sql, JComboBox combobox) {
        try {
            //Se abre la conexion utilizando el driver de oracle
           // DriverManager.registerDriver (new oracle.jdbc.OracleDriver());
            // ó Class.forName ("oracle.jdbc.OracleDriver");
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver"); 
            Connection conexion = DriverManager.getConnection(connectionUrl);
            Statement comando = conexion.createStatement();
            ResultSet resultado = comando.executeQuery(sql);
            
            //Para cada elemento retornado se agrega al combobox un "item" 
            while(resultado.next()) {
                combobox.addItem(resultado.getString(1));
            }
            
            //Hay que cerrar la conexion
            resultado.close();
            comando.close();
            conexion.close();
        } catch (Exception e) {
            //Es muy importante el try-catch para atrapar los posibles errores
            //que pueden ocurrir en las distintas consultas y comandos SQL
            System.out.println(e.getMessage());
        }
    }
 public void llenarTabla(String sql, JTable tabla) {
        try {
            //Para manejar los datos en un JTable se utiliza un modelo,
            //que por dejecto es "DefaultTableModel". Sin embargo queremos
            //utilizar uno personalizado para esta aplicaciÃ³n, por eso se creÃ³
            //DBTableModel. Si no estÃ¡ asignado (ni creado) hay que
            //hacerlo, de lo contrario solo hace falta actualizarlo.
            if( (tabla.getModel().getClass().toString()).equalsIgnoreCase("class pruebaconexion.DBTableModel") ) {
                //Se actualiza porque ya existe y lo tiene asignado
                ((DBTableModel) tabla.getModel()).actualizar(sql, connectionUrl);
            } else {
                //Se crea uno nuevo y se asigna
                DBTableModel modelo = new DBTableModel(sql, connectionUrl);
                tabla.setModel(modelo);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
}
