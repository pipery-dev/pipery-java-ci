package com.example;

public class Greeter {
    public String greet(String name) {
        return "Hello, " + name + "!";
    }

    public static void main(String[] args) {
        System.out.println(new Greeter().greet("Pipery"));
    }
}
