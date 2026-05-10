package com.qa.dashboard;

// Spring Boot's main annotation — explained below
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * QaDashboardApplication — Entry Point
 * ======================================
 * Every Java program starts at a method called main(). This is that method for
 * your entire Spring Boot application.
 *
 * What happens when you run this class:
 *   1. Java enters main()
 *   2. SpringApplication.run() is called
 *   3. Spring Boot starts up an embedded Tomcat web server on port 8080
 *   4. Spring scans all classes in this package (com.qa.dashboard) and its
 *      sub-packages to find Controllers, Services, etc.
 *   5. Your dashboard is live at http://localhost:8080
 *
 * Package structure note:
 *   This class lives at com.qa.dashboard — the "root" package.
 *   Spring Boot automatically scans all sub-packages (com.qa.dashboard.controller,
 *   com.qa.dashboard.model, etc.) so it finds your other classes without extra config.
 */

// @SpringBootApplication is a shortcut for three annotations combined:
//
//   @SpringBootConfiguration  — marks this as a Spring configuration class
//   @EnableAutoConfiguration  — tells Spring Boot to automatically set up things like
//                               the web server, FreeMarker, Jackson, etc., based on
//                               which JARs are on the classpath
//   @ComponentScan            — tells Spring to look for @Controller, @Service,
//                               @Repository, etc. classes in this package and below
//
// As a beginner, just remember: this one annotation wires everything together.
@SpringBootApplication
public class QaDashboardApplication {

    /**
     * main() — Java's universal entry point.
     *
     * @param args  Command-line arguments passed when starting the app.
     *              Spring Boot can use these to override properties, e.g.:
     *              java -jar app.jar --server.port=9090
     */
    public static void main(String[] args) {
        // SpringApplication.run() does all the heavy lifting:
        //   - Reads application.properties
        //   - Starts the embedded Tomcat server
        //   - Wires all your beans (controllers, services) together
        //   - Makes the app ready to handle HTTP requests
        SpringApplication.run(QaDashboardApplication.class, args);
    }
}
