/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package sistemadegestionacademica;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

/**
 *
 * @author nothing
 */
public class Notas {


    

    // ===================== Datos de la nota =====================

    private String asignatura;
    private String periodo;
    private double valor;

    public Notas(String asignatura, String periodo, double valor) {
        this.asignatura = asignatura;
        this.periodo = periodo;
        this.valor = valor;
    }

    public String getAsignatura() {
        return asignatura;
    }

    public String getPeriodo() {
        return periodo;
    }

    public double getValor() {
        return valor;
    }
    
    private static final List<String> asignaturas = new ArrayList<>();

    public static void agregarAsignatura(String nombre) {
        if (!asignaturas.contains(nombre)) {
            asignaturas.add(nombre);
        }
    }

    public static List<String> listarAsignaturas() {
        return Collections.unmodifiableList(asignaturas);
    }

   
    
    
}
