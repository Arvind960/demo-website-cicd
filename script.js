// Demo website JavaScript functionality
let buildCount = 0;
let scanCount = 0;
let deployCount = 0;

// Initialize counters from localStorage if available
window.addEventListener('DOMContentLoaded', function() {
    buildCount = parseInt(localStorage.getItem('buildCount') || '0');
    scanCount = parseInt(localStorage.getItem('scanCount') || '0');
    deployCount = parseInt(localStorage.getItem('deployCount') || '0');
    
    updateCounters();
    
    // Simulate real-time updates
    setInterval(simulateActivity, 30000); // Every 30 seconds
});

function updateCounters() {
    document.getElementById('build-count').textContent = buildCount;
    document.getElementById('scan-count').textContent = scanCount;
    document.getElementById('deploy-count').textContent = deployCount;
    
    // Save to localStorage
    localStorage.setItem('buildCount', buildCount.toString());
    localStorage.setItem('scanCount', scanCount.toString());
    localStorage.setItem('deployCount', deployCount.toString());
}

function incrementStats() {
    // Simulate pipeline execution
    const button = document.querySelector('.cta-button');
    button.textContent = 'Running Pipeline...';
    button.disabled = true;
    
    // Animate pipeline steps
    animatePipelineSteps();
    
    setTimeout(() => {
        buildCount++;
        scanCount++;
        deployCount++;
        updateCounters();
        
        button.textContent = 'Simulate Pipeline Run';
        button.disabled = false;
        
        showNotification('Pipeline completed successfully!');
    }, 3000);
}

function animatePipelineSteps() {
    const steps = document.querySelectorAll('.pipeline-step');
    
    steps.forEach((step, index) => {
        setTimeout(() => {
            step.classList.add('active');
            step.style.transform = 'scale(1.05)';
            setTimeout(() => {
                step.style.transform = 'scale(1)';
            }, 200);
        }, index * 500);
    });
}

function simulateActivity() {
    // Randomly increment counters to simulate background activity
    if (Math.random() > 0.7) {
        buildCount++;
        updateCounters();
    }
    
    if (Math.random() > 0.8) {
        scanCount++;
        updateCounters();
    }
    
    if (Math.random() > 0.9) {
        deployCount++;
        updateCounters();
    }
}

function showNotification(message) {
    // Create notification element
    const notification = document.createElement('div');
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 100px;
        right: 20px;
        background: linear-gradient(45deg, #4CAF50, #45a049);
        color: white;
        padding: 1rem 2rem;
        border-radius: 10px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        z-index: 1001;
        animation: slideIn 0.3s ease;
    `;
    
    // Add animation keyframes
    if (!document.querySelector('#notification-styles')) {
        const style = document.createElement('style');
        style.id = 'notification-styles';
        style.textContent = `
            @keyframes slideIn {
                from { transform: translateX(100%); opacity: 0; }
                to { transform: translateX(0); opacity: 1; }
            }
            @keyframes slideOut {
                from { transform: translateX(0); opacity: 1; }
                to { transform: translateX(100%); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    }
    
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Smooth scrolling for navigation links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add some interactive effects
document.addEventListener('mousemove', function(e) {
    const cursor = document.querySelector('.cursor');
    if (!cursor) {
        const newCursor = document.createElement('div');
        newCursor.className = 'cursor';
        newCursor.style.cssText = `
            position: fixed;
            width: 20px;
            height: 20px;
            background: rgba(255, 215, 0, 0.5);
            border-radius: 50%;
            pointer-events: none;
            z-index: 9999;
            transition: transform 0.1s ease;
        `;
        document.body.appendChild(newCursor);
    }
    
    const cursorElement = document.querySelector('.cursor');
    cursorElement.style.left = e.clientX - 10 + 'px';
    cursorElement.style.top = e.clientY - 10 + 'px';
});

// Console welcome message
console.log(`
🚀 Welcome to DevOps Demo Website!
📊 Current Stats:
   - Builds: ${buildCount}
   - Scans: ${scanCount}  
   - Deployments: ${deployCount}

This website demonstrates:
✅ Jenkins CI/CD Pipeline
✅ Docker Containerization
✅ SonarQube Code Analysis
✅ Automated Deployment

Built with ❤️ for DevOps demonstration
`);
