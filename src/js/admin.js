/** @param {HTMLFormControlsCollection} inputs - Form fields */
function disableFormControls(inputs) {
  for (var i = 0; i < inputs.length; i++) {
    inputs[i].setAttribute("disabled", "");
  }
}

/** @param {HTMLFormControlsCollection} inputs - Form fields */
function enableFormControls(inputs) {
  for (var i = 0; i < inputs.length; i++) {
    inputs[i].removeAttribute("disabled");
  }
}

/** @param {HTMLFormElement} form - The form */
async function prefillForm(form) {
  const params = (new URL(document.location.href)).searchParams;
  const feedbinId = params.get('feedbin_id')
  if (!feedbinId) {
    return;
  }

  const inputs = form.elements;
  disableFormControls(inputs);
  try {
    const response = await fetch(`/feedbin/entries/${feedbinId}`);
    if (!response.ok) {
      throw new Error('Network response was not ok.');
    }
    /** @type Object.<string, ?string> */
    const prefillData = await response.json();

    // Set the value of each field in the prefill data
    for (var fieldName in prefillData) {
      let field = inputs.namedItem(fieldName);
      let prefillValue = prefillData[fieldName];
      if (prefillValue && (field instanceof HTMLInputElement || field instanceof HTMLTextAreaElement)) {
        field.value = prefillValue;
      }
    }
  }
  catch (error) {
    console.log('There has been a problem with your fetch operation: ', error.message);
  }
  finally {
    enableFormControls(inputs);
  }
};

const form = document.getElementById('new-post-form');
if (form instanceof HTMLFormElement) {
  prefillForm(form);
}
