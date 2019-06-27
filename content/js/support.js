const $ = document.querySelectorAll.bind(document);
const E = document.createElement.bind(document);
const I = document.getElementById.bind(document);

// The maximum is exclusive and the minimum is inclusive
const getRandomInt = function(min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min)) + min;
}

function shuffleArray(array) {
  for (var i = array.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    const temp = array[i];
    array[i] = array[j];
    array[j] = temp;
  }
}

function range(min, maxExclusive) {
  var res = [];
  for (var i = 0; i < maxExclusive; i++) {
    res.push(i);
  }

  return res;
}

const highlightTag = function(tag) {
  const hash = "#" + tag;
  var tags = $('.filter .tag');
  for (var i = 0; i < tags.length; i++) {
    var a = tags[i];
    if (a.hash == hash) {
      a.classList.add('active');
    }
    else {
      a.classList.remove('active');
    }
  }
}

const filterCreators = function(tag) {
  if (I(tag) != null) { return } // anchor to specific person

  var creators = $('#creators .card');
  if (tag == '' || tag == 'all') {
    for (var i = 0; i < creators.length; i++) {
      var elem = creators[i];
      elem.classList.remove('hidden');
    }
  }
  else {
    for (var i = 0; i < creators.length; i++) {
      var elem = creators[i];
      if (elem.dataset.tags.split(',').indexOf(tag) == -1) {
        elem.classList.add('hidden');
      }
      else {
        elem.classList.remove('hidden');
      }
    }
  }

  highlightTag(tag);
}

const populateFeatured = function() {
  const NUM_CREATORS = 2;
  // Randomly select NUM_CREATORS creators. Some of the weirdness in this
  // function is due to the NodeList returned by $ being immutable and also
  // wanting to avoid picking the same person twice.
  var creators = $('#creators .card');
  var container = I('featured');
  if (container == null || creators.length < NUM_CREATORS * 2) {
    return;
  }

  var creatorsContainer = E('ul');
  creatorsContainer.className = 'creators';
  var indexes = range(0, creators.length);
  shuffleArray(indexes);

  for (var i = 0; i < NUM_CREATORS; i++) {
    var child = creators[indexes[i]].cloneNode(true);
    child.id += '_featured';
    child.classList.remove('hidden');
    creatorsContainer.appendChild(child);
  }

  var heading = E('h2');
  heading.innerText = 'Featured Rustaceans';
  container.appendChild(heading);
  container.appendChild(creatorsContainer);
}

window.onhashchange = function() {
  filterCreators(location.hash.replace('#', ''));
}

const ready = function(fn) {
  if (document.attachEvent ? document.readyState === "complete" : document.readyState !== "loading"){
    fn();
  } else {
    document.addEventListener('DOMContentLoaded', fn);
  }
}

ready(function() {
  filterCreators(location.hash.replace('#', ''));
  populateFeatured();
});
