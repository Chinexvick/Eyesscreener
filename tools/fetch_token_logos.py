"""Download real token logos from the Trust Wallet assets repo and write round 128px icons.

Usage: pip install pycryptodome pillow && python3 tools/fetch_token_logos.py
Tokens without a verified source keep the icon cropped from the mockup (see extract_assets.py).
"""
import sys, urllib.request, os
from Crypto.Hash import keccak
BASE="https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/%s/assets/%s/logo.png"
def cs(a):
    a=a.lower().replace('0x','')
    h=keccak.new(digest_bits=256,data=a.encode()).hexdigest()
    return '0x'+''.join(c.upper() if int(h[i],16)>=8 else c for i,c in enumerate(a))
cands={
 'babydoge':[('smartchain','0xc748673057861a797275cd8a068abb95a902e8de')],
 'floki':[('smartchain','0xfb5b838b6cfeedc2873ab27866079ac55363d37e'),('ethereum','0xcf0c122c6b73ff809c693db761e7baebe62b6a2e')],
 'pepe':[('smartchain','0x25d887ce7a35172c62febfd67a1856f20faebb00'),('ethereum','0x6982508145454ce325ddbe47a25d4ec3d2311933')],
 'doge':[('smartchain','0xba2ae424d960c26247dd6c32edc70b295c744c43')],
 'neiro':[('ethereum','0x812ba41e071c7b7fa4ebcfb62df5f45f6fa853ee'),('smartchain','0x812ba41e071c7b7fa4ebcfb62df5f45f6fa853ee')],
 'tst':[('smartchain','0x86bb94ddd16efc8bc58e6b056e8df71d9e666429')],
 'shibi':[('smartchain','0x2859e4544c4bb03966803b044a93563bd2d0dd4d'),('ethereum','0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE')],
 'wif':[('solana','EKpQGSJtjMFqKZ9KQanSqYXRcF8fBopzLHYxdM65zcjm')],
 'bome':[('solana','ukHH6c7mMyiWCf1b9pnWe25TSpkDDt3H5pQZgZ74J82')],
 'mew':[('solana','MEW1gQWJ3nEXg2qgERiKu7FAFj79PHvQVREQUzScPP5')],
 'ponke':[('solana','5z3EqYQo9HiCEs3R84RCDMu2n7anpDMxRhdK8PSWmrRC')],
 'bnb':[('smartchain','info')],
}
from io import BytesIO
from PIL import Image, ImageDraw
OUT=os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),'assets/img/tokens')
os.makedirs(OUT,exist_ok=True)
FILES={'shibi':'shibi','bnb':None}
def save(name,data):
    if name=='bnb': return
    im=Image.open(BytesIO(data)).convert('RGBA')
    side=min(im.size); im=im.crop(((im.width-side)//2,(im.height-side)//2,(im.width+side)//2,(im.height+side)//2)).resize((128,128),Image.LANCZOS)
    m=Image.new('L',(512,512),0); ImageDraw.Draw(m).ellipse((0,0,511,511),fill=255); im.putalpha(m.resize((128,128),Image.LANCZOS))
    im.save(os.path.join(OUT,name+'.png'))
for name,opts in cands.items():
    ok=False
    for chain,addr in opts:
        a=addr if chain=='solana' else (cs(addr) if addr!='info' else None)
        url=BASE%(chain,a) if a else "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/smartchain/info/logo.png"
        try:
            d=urllib.request.urlopen(urllib.request.Request(url,headers={'User-Agent':'x'}),timeout=15).read()
            save(name,d); print('OK  ',name,chain,len(d)); ok=True; break
        except Exception as e: print('fail',name,chain,e)
