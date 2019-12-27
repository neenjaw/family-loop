import axios from 'axios';

export const initializeDropArea = (dropAreaId) => {
  const dropArea = document.getElementById(dropAreaId);
  const form = dropArea.querySelector('form.upload__form');
  const url = form.action;
  const csrfToken = form.querySelector('input[name=_csrf_token]').value;

  ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, preventDefaults, false);
  });

  function preventDefaults (e) {
    e.preventDefault();
    e.stopPropagation();
  }

  ['dragenter', 'dragover'].forEach(eventName => {
    dropArea.addEventListener(eventName, highlight, false);
  });

  ['dragleave', 'drop'].forEach(eventName => {
    dropArea.addEventListener(eventName, unhighlight, false);
  });

  function highlight(e) {
    dropArea.classList.add('highlight');
  }

  function unhighlight(e) {
    dropArea.classList.remove('highlight');
  }

  dropArea.addEventListener('drop', handleDrop, false);

  function handleDrop(e) {
    const dt = e.dataTransfer;
    const files = dt.files;

    handleFiles(files);
  }

  function handleFiles(files) {
    ([...files]).forEach(uploadFile);
  }

  function uploadFile(file) {
    const formData = new FormData();
    formData.append('file', file)

    axios.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        'x-csrf-token': csrfToken
      },
      credentials: 'same-origin',
      onUploadProgress: function(progressEvent) {
        var percentCompleted = Math.round( (progressEvent.loaded * 100) / progressEvent.total );

        console.info(percentCompleted)
      }
    })
    .then(() => { /* Done. Inform the user */ console.info('success'); })
    .catch(() => { /* Error. Inform the user */ console.error('fail'); })
  }
};

