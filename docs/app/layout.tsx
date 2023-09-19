import Navbar from '@/components/navbar'
import Footer from '@/components/footer'
import '@/css/tailwind.css'

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <>
            <Navbar />
            {children}
            <Footer />
        </>
    )
}
