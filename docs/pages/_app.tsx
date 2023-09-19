import RootLayout from "@/app/layout";

export default function App({ Component, pageProps }: any) {
    return (
        <RootLayout>
            <Component {...pageProps} />
        </RootLayout>
    )
}