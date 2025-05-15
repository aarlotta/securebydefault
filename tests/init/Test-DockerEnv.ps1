# Test-DockerEnv.ps1
# Verifies that secure Docker image and structure exist

Describe "Secure Docker Environment" {
    It "Dockerfile should exist" {
        Test-Path "../../resources/docker/Dockerfile" | Should -BeTrue
    }

    It "Docker image should be buildable" {
        docker image inspect securebydefault/base -f "{{.Id}}" | Should -Not -BeNullOrEmpty
    }
}
























