const eleventyNavigationPlugin = require("@11ty/eleventy-navigation");

const markdownIt = require('markdown-it')
const markdownItAttrs = require('markdown-it-attrs')

const markdownItOptions = {
    html: true,
    breaks: true,
    linkify: true
}

const markdownLib = markdownIt(markdownItOptions).use(markdownItAttrs)
eleventyConfig.setLibrary('md', markdownLib)

module.exports = function(eleventyConfig) {
    // Do NOT erase the two lines below...
    eleventyConfig.addPassthroughCopy("./static/images");
    eleventyConfig.addPassthroughCopy("./**./**/*.{jpg,png,svg}");

    eleventyConfig.addPlugin(eleventyNavigationPlugin);


    return {
        markdownTemplateEngine: "njk",
        htmlTemplateEngine: "njk",
        dir: {
            // default: [site root]
            input: "static",
            // default: _site
            output: "_site",
        },
    };
};