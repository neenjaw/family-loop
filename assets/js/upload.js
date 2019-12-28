import axios from 'axios';

export const initializeDropArea = (dropAreaId) => {
  const dropArea = document.getElementById(dropAreaId);
  const form = dropArea.querySelector('form.upload__form');
  const url = form.action;
  const csrfToken = form.querySelector('input[name=_csrf_token]').value;
  const gallery = dropArea.querySelector('.upload__gallery');

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
    ['dragenter', 'dragover'].forEach(eventName => {
      dropArea.removeEventListener(eventName, highlight);
    });

    dropArea.removeEventListener('drop', handleDrop);

    Promise.all(([...files]).map(uploadFile))
    .then(() => { console.info('all done'); window.location.search += '&upload=success'; })
    .catch(() => console.error('Error uploading'));
  }

  function uploadFile(file) {
    const formData = new FormData();
    formData.append('file', file)

    const [node, container, progressBar, percent] = createGalleryItem(file);
    addGalleryItemToGallery(node);

    return axios.post(url, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
        'x-csrf-token': csrfToken
      },
      credentials: 'same-origin',
      onUploadProgress: updateGalleryItemProgress(progressBar, percent)
    })
    .then(() => { /* Done. Inform the user */ console.info('success'); })
    .catch(() => { /* Error. Inform the user */ console.error('fail'); });
  }

  function createGalleryItem(file) {
    const progress = document.createElement('progress');
    progress.max = 100;
    progress.value = 0;

    const percent = document.createElement('span');
    percent.insertAdjacentText('afterbegin', '0');

    const holder = document.createElement('span');
    holder.appendChild(progress);
    holder.appendChild(percent);
    percent.insertAdjacentText('afterend', '%');
    progress.insertAdjacentText('afterend', ' ');

    const name = document.createElement('span');
    const fileName = (file.name.length <= 21) ? file.name : `${file.name.slice(0,9)}...${file.name.slice(-9)}`;
    name.insertAdjacentText('afterbegin', fileName);

    const container = document.createElement('div');
    container.classList.add('gallery__item');
    container.appendChild(name);
    container.appendChild(holder);

    const node = document.createDocumentFragment();
    node.appendChild(container);

    gallery.appendChild(node);

    return [node, container, progress, percent];
  }

  function addGalleryItemToGallery(node) {
    if (gallery) gallery.appendChild(node);
  }

  function updateGalleryItemProgress(progressBar, percent) {
    if (gallery == null) return () => {};

    return (progressEvent) => {
      const value = Math.round( (progressEvent.loaded * 100) / progressEvent.total );
      progressBar.value = value;
      percent.innerText = value;
    }
  }
};

