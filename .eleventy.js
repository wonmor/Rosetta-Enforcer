module.exports = function(eleventyConfig) {
    eleventyConfig.addPassthroughCopy("{{'./sources/images' | url }}");

    return {
        dir: {
            // default: [site root]
            input: "static",
            // default: _site
            output: "_site",
        },
    };
};