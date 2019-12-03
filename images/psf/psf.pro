FUNCTION psf_deconvl, tezina, fwhm, npix, cdelt
;fwhm je u lucnim sekundama, prevesti u pixele zato sto ovaj psf
;radi tako
;cdelt je velicina piksela u lucnim sekundama
;tezina - weight of gaussian
; fwhm - fwhm of gaussian
; npix - size of final psf in pixels
; cdelt - pixel size in arcsec
; example caling:
; psf = psf_deconvl(tezina_b,fwhm_b,30,0.10896, 50)
;final result is normalised gaussian

    cdelt = 0.10896
    fwhm = fwhm / cdelt
    psf1 = psf_Gaussian(NPIXEL=npix, FWHM=fwhm[0], /double, /normal ) * tezina[0]
    psf2 = psf_Gaussian(NPIXEL=npix, FWHM=fwhm[1], /double, /normal ) * tezina[1]
    psf3 = psf_Gaussian(NPIXEL=npix, FWHM=fwhm[2], /double, /normal ) * tezina[2]
    psf4 = psf_Gaussian(NPIXEL=npix, FWHM=fwhm[3], /double, /normal ) * tezina[3]
    PSF = psf1 + psf2 + psf3 + psf4
    RETURN, PSF/max(PSF)
END

Pro psf_correction, put, niter, filter, type
;put - location to image
;niter - number of itteration in deconvolution process
;type - which method you want to use to deconvolve function integer
; - likelihood = 1
; - entropy = 2 FAULTY AS SHIT!!!!! USE LIKELIHOOD!!!
;filter - filter for which we make PSF
;   - 6684 - red continuum
;   - 5550 - green continuum
;   - 4504 - blue continuum
    x = READFITS(put)
    header = HEADFITS(put)
    cgdisplay, 300, 300
    cgimage, x
    tezina_r = [0.6228d, 0.1601d, 0.0927d, 0.1243d]
    fwhm_r = [0.2188d, 0.8181d, 1.8330d, 19.018d]

    tezina_g = [0.6250d, 0.1698d, 0.0920d, 0.1131d]
    fwhm_g = [0.1960d, 0.6505d, 1.6888d, 18.686d]

    tezina_b=[0.6423d, 0.1748d, 0.105d, 0.078d]
    fwhm_b=[0.1390d, 0.5212d, 1.6844d, 19.173d]

    case filter of
    6684: begin
            tezina = tezina_r
            fwhm = fwhm_r
          end
    5550: begin
            tezina = tezina_g
            fwhm = fwhm_g
          end
    4504: begin
            tezina = tezina_b
            fwhm = fwhm_b
          end
    endcase

    psf = psf_deconvl(tezina, fwhm, 30, 0.10896)
    string_pos = strpos(put, '.fit')

;nitter je definisano
    case type of
    1:  begin
    for i=1,niter do Max_Likelihood, x, PSF, deconv, multipliers
    value = 'Deconvolved with maximum_likelihood method from astron library with ' + strtrim(string(Niter), 2) + ' itterations'
    name = strmid(put, 0, string_pos) + '_niter_' + strtrim(string(Niter),2) + '_max_like.fit'
        end
    2:  begin
    for i=1,niter do Max_Entropy, x, PSF, deconv, multipliers
    value = 'Deconvolved with maximum_entropy method from astron library with ' + strtrim(string(Niter), 2) + ' itterations'
    name = strmid(put, 0, string_pos) + '_niter_' + strtrim(string(Niter),2) + '_max_ent.fit'
        end
    endcase

    sxaddpar, header, 'COMMENT', value

    cgdisplay, 300, 300
    cgimage, deconv
    MWRFITS, deconv, name, header

END
