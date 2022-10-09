// ==UserScript==
// @name Youtube sidebar
// @namespace http://mirekng.com/
// @version 0.1
// @description Remove sidebar
// @author Mirek Nguyen
// @match *://*.youtube.com/*
// @grant none
// @run-at document-start
// ==/UserScript==
document.querySelector("#guide").removeAttribute("opened");
document.querySelector("#page-manager").style.marginLeft = 0;