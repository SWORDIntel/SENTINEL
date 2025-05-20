# MDMAPanel

A powerful real-time target management and monitoring system built with modern web technologies. MDMAPanel provides comprehensive tools for tracking, managing, and interacting with targets in real-time.

[![CI Status](https://github.com/xtial/mdmapanel/workflows/CI/badge.svg)](https://github.com/xtial/mdmapanel/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[Quick Start](#-installation) | [Documentation](#-documentation) | [Contributing](#-contributing) | [Support](#-support)

## 🚀 Features

### Core Features
- **Real-time Monitoring**
  - Live target status updates
  - Real-time activity tracking
  - Instant notification system
  
- **Advanced Management**
  - Multi-target control
  - Custom action deployment
  - Batch operations support
  
- **Security & Authentication**
  - Role-based access control
  - Secure JWT authentication
  - Session management
  
- **Guild System**
  - Multi-guild support
  - Custom domain management
  - Guild-specific settings

### Additional Features
- Sound notification system
- Email notification integration
- Custom domain management
- Extensive API endpoints
- Real-time WebSocket communication
- Responsive dashboard interface

## 📋 Documentation

### Getting Started
- [Getting Started Guide](docs/getting-started.md) - Quick setup and first steps
- [Architecture Overview](docs/architecture.md) - System design and components
- [Database Schema](docs/database.md) - Database structure and relationships
- [Security Guide](docs/security.md) - Security measures and best practices

### Feature Documentation
- [Guild System](docs/features/guild-system.md) - Multi-tenant guild management
- [Target Management](docs/features/target-management.md) - Target tracking and control

### API Documentation
- [API Reference](docs/api/README.md) - Complete API documentation
- [WebSocket Events](docs/api/websocket.md) - Real-time event documentation

### Configuration
- [Environment Variables](docs/config/env-vars.md) - Configuration options
- [Deployment Guide](docs/deployment.md) - Production deployment

### Maintenance
- [Backup and Recovery](docs/maintenance/backup.md) - Data backup procedures
- [Monitoring Guide](docs/maintenance/monitoring.md) - System monitoring

## 📋 Prerequisites

Before you begin, ensure you have the following installed:
- Node.js (v16.x or higher)
- PostgreSQL (v12.x or higher)
- npm (v7.x or higher) or yarn (v1.22.x or higher)
- Git

## 🛠 Installation

1. **Clone the Repository**
   ```bash
   git clone https://github.com/xtial/mdmapanel.git
   cd mdmapanel
   ```

2. **Install Dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

3. **Database Setup**
   ```bash
   # Create PostgreSQL database
   createdb mdmapanel

   # Initialize schema
   psql -d mdmapanel -f schema.sql

   # (Optional) Add sample data
   psql -d mdmapanel -f seed.sql
   ```

4. **Environment Configuration**
   Create a `.env` file in the root directory:
   ```env
   DATABASE_URL=postgresql://postgres:postgres@localhost:5432/mdmapanel
   JWT_SECRET=your_jwt_secret_here
   SMTP_HOST=your_smtp_host
   SMTP_PORT=587
   SMTP_USER=your_smtp_username
   SMTP_PASS=your_smtp_password
   ```

5. **Start Development Server**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

   Access the application at `http://localhost:5173`

## 🚀 Deployment

See our comprehensive deployment guides for detailed instructions:
- [VPS Hosting Guide](docs/hosting/vps-setup.md) - Complete guide for VPS deployment
- [Deployment Guide](docs/deployment.md) - General deployment instructions

These guides cover:
- Development environment setup
- Production deployment
- Server configuration
- Security measures
- Monitoring and maintenance
- Performance optimization
- Scaling strategies

## 🔒 Security

Security is a top priority. See our [Security Guide](docs/security.md) for:
- Authentication and authorization
- Data encryption
- Security best practices
- Regular security updates
- Vulnerability reporting
- Compliance guidelines

## 🤝 Contributing

We welcome contributions! See our [Contributing Guide](CONTRIBUTING.md) for:
- Code of conduct
- Development workflow
- Pull request process
- Coding standards
- Testing requirements
- Documentation guidelines

## 💬 Support

Need help? We've got you covered:
- [Documentation](#-documentation) - Comprehensive guides and references
- [GitHub Issues](https://github.com/xtial/mdmapanel/issues) - Bug reports and feature requests
- Discord Community - Real-time community support

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👏 Acknowledgments

- SvelteKit team for the amazing framework
- Socket.IO team for real-time capabilities
- All our contributors and supporters

## 🔄 Version History

See [CHANGELOG.md](CHANGELOG.md) for details about versions and updates.
