/** @type {import('next').NextConfig} */
const nextConfig = {
    output: 'export',
    images: {
        loader: 'custom',
        loaderFile: './src/image-loader.ts',
    }
}

module.exports = nextConfig
