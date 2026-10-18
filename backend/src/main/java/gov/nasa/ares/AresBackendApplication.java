package gov.nasa.ares;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AresBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(AresBackendApplication.class, args);
    }
}
