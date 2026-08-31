package com.example;

/**
 * hello-lib — a tiny library whose only job is to prove that a Maven
 * artifact was built, deployed to Artifact Keeper, and can be resolved
 * again as a dependency.
 */
public final class HelloLib {

    private HelloLib() {
        // utility class
    }

    /** Returns the library name and version. */
    public static String name() {
        return "hello-lib";
    }

    /** Returns the version — keep in sync with pom.xml. */
    public static String version() {
        return "1.0.0";
    }

    /** Greets a caller by name. */
    public static String greet(String who) {
        return String.format("Hello, %s! (from %s v%s)",
                who == null || who.isBlank() ? "world" : who,
                name(),
                version());
    }
}
