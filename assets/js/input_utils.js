
export default function installListeners() {
	const elementsToDisable = document.querySelectorAll("[data-disabled-when-empty]");

	elementsToDisable.forEach(el => {
		const sourceEl = document.querySelector(el.dataset.disabledWhenEmpty);

		el.disabled = (sourceEl.value === '');
		
		const updateDisabledState = (event) => { el.disabled = (event.target.value === '') };

		sourceEl.addEventListener('change', updateDisabledState);
		sourceEl.addEventListener('input', updateDisabledState);
	});
};

