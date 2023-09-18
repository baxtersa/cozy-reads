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
                CozyReads is a reading habit tracker with a personal touch. Set goals, track
                your progress, and visualize your taste in books without the pressure of a
                social media community and comparison culture. Customize tags and filter graphs
                however you wish. Plan out your "To Read" list so that you are always looking
                forward to your next book.
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
