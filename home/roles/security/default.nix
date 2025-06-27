/*
`home/roles/security/default.nix`
Security and cybersecurity tools

This role module provides packages and configurations for security-focused
work, including penetration testing, security analysis, and defensive
security tools. It's designed for users who work in cybersecurity or
need security tools for their work.

Purpose:
- Groups security-specific tools separately from general development
- Enables security-focused machine configurations
- Provides tools for both offensive and defensive security
- Supports cybersecurity professionals and security research

Usage:
- Imported by hosts used for security work or research
- Can be combined with dev role for security-focused development
- Useful for penetration testing, incident response, and security analysis

Architecture:
- Part of the role-based package organization system
- Complements other roles: dev, work, personal, docker
- Focuses on security tools and configurations
- May include specialized security distributions and tools

Examples of what this role might include when implemented:
- Network security tools (nmap, wireshark, metasploit)
- Cryptographic tools and analysis
- Reverse engineering and binary analysis
- Web application security testing
- Incident response and forensics tools
- Vulnerability scanners and assessment tools
*/
_: {
  # Placeholder for security-specific packages and configurations
  # When implemented, this might include:

  # home.packages = with pkgs; [
  #   # Network security and analysis
  #   nmap # Network discovery and security auditing
  #   wireshark # Network protocol analyzer
  #   tcpdump # Command-line packet analyzer
  #   aircrack-ng # Wireless network security testing
  #
  #   # Web application security
  #   burpsuite # Web application security testing
  #   sqlmap # SQL injection testing tool
  #   dirb # Web content scanner
  #
  #   # Cryptography and analysis
  #   hashcat # Password cracking tool
  #   john # Password cracking tool
  #   openssl # Cryptographic toolkit
  #
  #   # Reverse engineering
  #   ghidra # Software reverse engineering suite
  #   radare2 # Reverse engineering framework
  #
  #   # Forensics and incident response
  #   volatility3 # Memory forensics framework
  #   sleuthkit # Digital forensics tools
  #
  #   # Vulnerability assessment
  #   nikto # Web server scanner
  #
  #   # System security
  #   rkhunter # Rootkit hunter
  #   chkrootkit # Rootkit checker
  # ];

  # programs = {
  #   # Security-specific program configurations
  #   # These might include specialized security tool configurations
  # };
}
