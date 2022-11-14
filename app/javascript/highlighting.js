function annotationsForTokenId(tokenId) {
  return $(".annotation").filter(function(index, annotation) {
    return $(annotation).attr("data-token-ids").split(" ").includes(tokenId);
  });
}

function tokenSpanForId(tokenId) {
  return $(`#command span[data-token-id=${tokenId}]`);
}

function setupHighlighting() {
  $("#command span").hover(
    function() {
      let tokenId = $(this).attr("data-token-id");
      let annotations = annotationsForTokenId(tokenId);
      $(this).addClass("highlighted");
      annotations.addClass("highlighted");
    },
    function() {
      let tokenId = $(this).attr("data-token-id");
      let annotations = annotationsForTokenId(tokenId);
      $(this).removeClass("highlighted");
      annotations.removeClass("highlighted");
    }
  );

  $(".annotation").hover(
    function() {
      let tokenIds = $(this).attr("data-token-ids").split(" ");
      $(this).addClass("highlighted");
      tokenIds.forEach(function(tokenId) {
        tokenSpanForId(tokenId).addClass("highlighted");
      });
    },
    function() {
      let tokenIds = $(this).attr("data-token-ids").split(" ");
      $(this).removeClass("highlighted");
      tokenIds.forEach(function(tokenId) {
        tokenSpanForId(tokenId).removeClass("highlighted");
      });
    }
  );
}

$(document).ready(function(){
  setupHighlighting();
});