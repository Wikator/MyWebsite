document.addEventListener('DOMContentLoaded', () => {
    const alertElement = document.querySelector('.alert');
    console.log(alertElement);
    if (alertElement) {
        let alert = new bootstrap.Alert(alertElement);
        setTimeout(() => {
            alert.close();
        }, 3000); // Close the alert after 3 seconds
    }
});