package com.example;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class GreeterTest {
    @Test
    public void testGreet() {
        Greeter greeter = new Greeter();
        assertEquals("Hello, Pipery!", greeter.greet("Pipery"));
    }
}
