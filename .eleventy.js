const eleventyNavigationPlugin = require("@11ty/eleventy-navigation");

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