/** @type {import('next').NextConfig} */
const nextConfig = {
    output: 'export',
    images: {
        loader: 'custom',
        loaderFile: './src/image-loader.ts',
    },
    assetPrefix: '/cozy-reads/',
    basePath: '/cozy-reads/'
}

module.exports = nextConfig
