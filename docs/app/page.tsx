import Hero from '@/components/hero'
import Navbar from '@/components/navbar'
import SectionTitle from '@/components/sectionTitle'
import { Features, featureDevices, featureOne, featureIAP } from '@/components/features'


export default function Home() {
    return (
        <>
            <Navbar />
            <Hero />
            <SectionTitle pretitle="CozyReads Features" title="What you get with CozyReads">
                This section is to highlight a promo or demo video of your product.
                Analysts says a landing page with video has 3% more conversion rate. So,
                don&apos;t forget to add one. Just like this.
            </SectionTitle>
            <Features data={featureDevices} imgPos='right' />
            <Features data={featureOne} imgPos={undefined} />
            <Features data={featureIAP} imgPos='right' />
            <SectionTitle pretitle="FAQ" title="Frequently Asked Questions">
                Common questions are answered below. Please open an Issue on the
                Github page for further support.
            </SectionTitle>
        </>
    )
}
