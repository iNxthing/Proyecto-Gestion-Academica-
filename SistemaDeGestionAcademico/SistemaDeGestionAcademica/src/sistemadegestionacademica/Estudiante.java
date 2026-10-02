package sistemadegestionacademica;

import java.util.ArrayList;
import java.util.List;


public class Estudiante {


    private String nombreEstudiante;
    private String gradoEstudiante;
    private final List<Notas> notas = new ArrayList<>();

    public Estudiante(String nombreEstudiante, String gradoEstudiante) {
        this.nombreEstudiante = nombreEstudiante;
        this.gradoEstudiante = gradoEstudiante;
    }

    public String getNombreEstudiante() {
        return nombreEstudiante;
    }

    public void setNombreEstudiante(String nombreEstudiante) {
        this.nombreEstudiante = nombreEstudiante;
    }

    public String getGradoEstudiante() {
        return gradoEstudiante;
    }

    public void setGradoEstudiante(String gradoEstudiante) {
        this.gradoEstudiante = gradoEstudiante;
    }

    
    public List<Notas> getNotas() {
        return notas;
    }

    public void agregarNota(String asignatura, String periodo, double valor) {
        notas.add(new Notas(asignatura, periodo, valor));
    }

    public double calcularPromedio() {
        if (notas.isEmpty()) {
            return 0;
        }
        double suma = 0;
        for (Notas n : notas) {
            suma += n.getValor();
        }
        return suma / notas.size();
    }

    public boolean aprobo(double notaMinima) {
        return calcularPromedio() >= notaMinima;
    }

    public List<Notas> filtrarNotas(String asignatura, String periodo) {
        List<Notas> resultado = new ArrayList<>();
        for (Notas n : notas) {
            if (n.getAsignatura().equals(asignatura)
                    && n.getPeriodo().equals(periodo)) {
                resultado.add(n);
            }
        }
        return resultado;
    }

    private static final List<Estudiante> estudiantes = new ArrayList<>();

    public static Estudiante crearEstudiante(String nombre, String grado) {
        Estudiante nuevo = new Estudiante(nombre, grado);
        estudiantes.add(nuevo);
        return nuevo;
    }

    public static List<Estudiante> obtenerEstudiantes() {
        return estudiantes;
    }

    public static Estudiante buscarPorNombre(String nombre) {
        for (Estudiante e : estudiantes) {
            if (e.getNombreEstudiante().equalsIgnoreCase(nombre)) {
                return e;
            }
        }
        return null;
    }

    public static List<Estudiante> filtrarPorGrado(String nombreGrado) {
        List<Estudiante> resultado = new ArrayList<>();
        for (Estudiante e : estudiantes) {
            if (e.getGradoEstudiante().equalsIgnoreCase(nombreGrado)) {
                resultado.add(e);
            }
        }
        return resultado;
    }

    public static List<Estudiante> filtrarBajoRendimiento(double limite) {
        List<Estudiante> resultado = new ArrayList<>();
        for (Estudiante e : estudiantes) {
            if (!e.getNotas().isEmpty() && e.calcularPromedio() < limite) {
                resultado.add(e);
            }
        }
        return resultado;
    }
}
