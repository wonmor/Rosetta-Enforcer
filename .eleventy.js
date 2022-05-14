const eleventyNavigationPlugin = require("@11ty/eleventy-navigation");

const pluginTOC = require('eleventy-plugin-toc')

const markdownIt = require('markdown-it')
const markdownItAnchor = require('markdown-it-anchor')

module.exports = function(eleventyConfig) {
    // Do NOT erase the two lines below...
    eleventyConfig.addPassthroughCopy("./static/images");
    eleventyConfig.addPassthroughCopy("./**./**/*.{jpg,png,svg}");
    eleventyConfig.addPassthroughCopy("./dist/output.css");

    eleventyConfig.addPlugin(eleventyNavigationPlugin);
    eleventyConfig.addPlugin(pluginTOC)

    eleventyConfig.setLibrary(
        'md',
        markdownIt().use(markdownItAnchor)
    )

    return {
        markdownTemplateEngine: "njk",
        htmlTemplateEngine: "njk",
        dir: {
            // default: [site root]
            input: "static",
            // default: _site
            includes: "_includes",
            output: "_site",
        },
    };
};