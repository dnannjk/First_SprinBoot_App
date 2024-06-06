package com.myfirstdeployment.project.controllers;
import java.util.List;

import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.myfirstdeployment.project.data.User;

@RestController
@RequestMapping("/api/v1/")
public class ProfileController {

    @GetMapping(value = "users", produces = MediaType.APPLICATION_JSON_VALUE)
    public List<User> getUser() {
        return List.of(new User("Deepali", "Kolapkar", "pradeepkolapkar@gmail.com"), new User("Vivaan", "Nannajkar", "deepali.nannjakar95@gmail.com"));
    }
}