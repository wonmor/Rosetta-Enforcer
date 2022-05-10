module.exports = function(eleventyConfig) {
    eleventyConfig.addPassthroughCopy("./static/images");
    eleventyConfig.addPassthroughCopy("./**./**/*.{jpg,png,svg}");

    return {
        dir: {
            // default: [site root]
            input: "static",
            // default: _site
            output: "_site",
        },
    };
};

async function imageShortcode(src, alt, sizes) {
    let metadata = await Image(path.join(__dirname, src), {
        outputDir: "./_site/images/",
        urlPath: "/_site/images",
        widths: [300, 600, 900, 1200],
        formats: ["avif", "webp", "jpg", "png"],
    });

    let imageAttributes = {
        alt,
        sizes,
        loading: "lazy",
        decoding: "async",
    };

    return Image.generateHTML(metadata, imageAttributes);
}