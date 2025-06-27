/*
`home/roles/docker/default.nix`
Docker and container-related tools

This role module provides packages and configurations for containerization
and orchestration work. It's designed for users who work extensively with
Docker, container orchestration, and cloud-native technologies.

Purpose:
- Groups container-related tools separately from general development
- Enables container-focused development environments
- Provides tools for both development and production container workflows
- Supports DevOps and cloud-native development patterns

Usage:
- Imported by hosts used for container development or DevOps work
- Can be combined with dev role for containerized application development
- Useful for microservices development and container orchestration

Architecture:
- Part of the role-based package organization system
- Complements other roles: dev, work, personal, security
- Focuses on containerization and orchestration tools
- May include cloud-native development and deployment tools

Examples of what this role might include when implemented:
- Docker and container runtime tools
- Kubernetes and container orchestration
- Container image building and management
- Service mesh and cloud-native tools
- Container security and monitoring
*/
_: {
  # Placeholder for Docker and container-specific packages and configurations
  # When implemented, this might include:

  # home.packages = with pkgs; [
  #   # Core container tools
  #   docker # Container runtime and management
  #   docker-compose # Multi-container application orchestration
  #   podman # Alternative container runtime
  #   buildah # Container image building tool
  #
  #   # Kubernetes and orchestration
  #   kubectl # Kubernetes command-line tool
  #   kubernetes-helm # Kubernetes package manager
  #   k9s # Kubernetes cluster management TUI
  #   kubectx # Kubernetes context switching
  #
  #   # Container image tools
  #   skopeo # Container image inspection and management
  #   dive # Container image layer analysis
  #
  #   # Development and debugging
  #   kind # Kubernetes in Docker for local development
  #   minikube # Local Kubernetes development
  #   ctop # Container monitoring TUI
  #
  #   # Cloud-native tools
  #   istioctl # Service mesh management
  #   linkerd # Lightweight service mesh
  #
  #   # Container security
  #   trivy # Container vulnerability scanner
  #
  #   # Registry and distribution
  #   regctl # Container registry client
  # ];

  # programs = {
  #   # Docker and container-specific program configurations
  #   # These might include Docker daemon configuration, registry settings, etc.
  # };
}
