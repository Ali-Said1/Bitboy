const contentSelector = document.querySelectorAll("aside ul li")
const sections = document.querySelectorAll("section")

contentSelector.forEach(item => {
    item.addEventListener('click', (event) => {
        const index = Array.from(contentSelector).indexOf(event.target);
        for (selector of contentSelector) {
            selector.classList.remove('selected')
        }
        for (section of sections) section.classList.add('visually-hidden')
        event.target.classList.add('selected')
        sections[index].classList.remove('visually-hidden')
        console.log(`You clicked on item number ${index}`);
    });
});