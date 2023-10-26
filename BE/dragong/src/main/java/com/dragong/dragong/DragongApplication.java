package com.dragong.dragong;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@EnableJpaAuditing
@SpringBootApplication
public class DragongApplication {

	public static void main(String[] args) {
		SpringApplication.run(DragongApplication.class, args);
	}

}
